From: Shirley Ma <xma@us.ibm.com>
Subject: Re: Re: [PATCH] net: Move destructor from
	neigh->ops	to neigh_params
Date: Mon, 6 Mar 2006 21:40:54 -0800
Message-ID: <OF7424974D.E6456B1D-ON8725712A.001F0149-8825712A.001EE351@us.ibm.com>
References: <20060306211630.0df79464.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1174386419=="
Cc: netdev@vger.kernel.org, openib-general-bounces@openib.org,
	davem@davemloft.net, openib-general@openib.org,
	Roland Dreier <rdreier@cisco.com>
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <20060306211630.0df79464.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============1174386419==
Content-Type: multipart/alternative;
	boundary="=_alternative 001EE3498825712A_="

This is a multipart message in MIME format.
--=_alternative 001EE3498825712A_=
Content-Type: text/plain; charset="US-ASCII"

>I'm also wondering why a combination of the net and infiniband trees does 
this:

>drivers/infiniband/ulp/ipoib/ipoib_multicast.c: In function 
`ipoib_mcast_free':
>drivers/infiniband/ulp/ipoib/ipoib_multicast.c:118: error: structure has 
no member named `destructor'

I guess this patch needs to be combined with another ipoib-neigh patch, 
which hasn't been checked into infiniband/ipoib yet.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone(Fax): (503) 578-7638


--=_alternative 001EE3498825712A_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2><tt>&gt;I'm also wondering why a combination of the net
and infiniband trees does this:<br>
<br>
&gt;drivers/infiniband/ulp/ipoib/ipoib_multicast.c: In function `ipoib_mcast_free':<br>
&gt;drivers/infiniband/ulp/ipoib/ipoib_multicast.c:118: error: structure
has no member named `destructor'<br>
</tt></font>
<br><font size=2 face="sans-serif">I guess this patch needs to be combined
with another ipoib-neigh patch, which hasn't been checked into infiniband/ipoib
yet.<br>
</font>
<br><font size=2 face="sans-serif">Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone(Fax): (503) 578-7638<br>
<br>
</font>
--=_alternative 001EE3498825712A_=--

--===============1174386419==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1174386419==--
