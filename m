From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Fri, 6 Feb 2004 22:40:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF92ABDC1A.4056C324-ON88256E33.002267FA-88256E33.00247258@us.ibm.com>
References: <20040207.142519.117436499.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4A0DFB1E16A8f9e8a93df938690918c07BBE4A0DFB1E16A"
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040207.142519.117436499.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4A0DFB1E16A8f9e8a93df938690918c07BBE4A0DFB1E16A
Content-type: text/plain; charset=US-ASCII





Good idea; I'll incorporate all the comments, retest and repost.

> So... hmm... Let's check dev->flags ^ (IFF_PROMISC|IFF_ALLMULTI) like
this.

      I think you mean (dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) here,
right?

> I don't think it is so costy for usual operation.
> If you think it is, please introduce hash table for mc_list in idev;
> it should have been "heavy." :-)
> (You can do it later, of course.)

This certainly could be done and I had this in mind for the future when
I designed the interface filter data structures (made sure everything
for the intersection and union is directly available given only the
ifmcaddr). I should do some testing to see how many MCA's or source
filters are needed to make a hash worthwhile, and maybe how many before
it falls over. :-)
                        thanks!
                              +-DLS
--0__=07BBE4A0DFB1E16A8f9e8a93df938690918c07BBE4A0DFB1E16A
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Good idea; I'll incorporate all the comments, retest and repost.<br>
<br>
<tt>&gt; So... hmm... Let's check dev-&gt;flags ^ (IFF_PROMISC|IFF_ALLMULTI) like this.</tt><br>
<br>
<tt>	I think you mean (dev-&gt;flags &amp; (IFF_PROMISC|IFF_ALLMULTI)) here, right?</tt><br>
<tt><br>
&gt; I don't think it is so costy for usual operation.<br>
&gt; If you think it is, please introduce hash table for mc_list in idev;<br>
&gt; it should have been &quot;heavy.&quot; :-)<br>
&gt; (You can do it later, of course.)<br>
</tt><br>
<tt>This certainly could be done and I had this in mind for the future when<br>
I designed the interface filter data structures (made sure everything</tt><br>
<tt>for the intersection and union is directly available given only the</tt><br>
<tt>ifmcaddr). I should do some testing to see how many MCA's or source</tt><br>
<tt>filters are needed to make a hash worthwhile, and maybe how many before</tt><br>
<tt>it falls over. :-)</tt><br>
<tt>				thanks!</tt><br>
<tt>					+-DLS</tt></body></html>
--0__=07BBE4A0DFB1E16A8f9e8a93df938690918c07BBE4A0DFB1E16A--
