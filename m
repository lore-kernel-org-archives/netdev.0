From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Kernel 2.4.22 MLD problems
Date: Thu, 11 Dec 2003 15:19:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF606B371E.03D6C1CF-ON88256DF9.007F6B6C@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE76ADFECEDFC8f9e8a93df938690918c07BBE76ADFECEDFC"
Return-path: <netdev-bounce@oss.sgi.com>
To: Takashi Hibi <hibi665@oki.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE76ADFECEDFC8f9e8a93df938690918c07BBE76ADFECEDFC
Content-type: text/plain; charset=US-ASCII






Takashi,

>>But there are still some problems.
>>[MLDv2]
>>1. After joining multicast address, MLDv2 listener report isn't issued
>>immediately.
>
>This looks like a bug; it should send the first one immediately,
>and QRV-1 more at random intervals between 0 and MRC. It's adding
>the MRC random delay before sending the first one. Not critical,
>but I'll put a patch together in the next couple of days.

I thought this was a bug, from a quick glance at the code, but I
just looked some more and it already does the fix I had in mind.
I also ran some tests, and I do see the advertisement immediately
after an interface state change. That was with 2.6.0-test11bk8,
but 2.4.22 has the same code for this piece.

In MLDv1 compatibility mode, interface state changes are not sent, but a
"leave group" will result in an MLDv1 leave group message. So, I can't
explain (or reproduce) this behaviour right now.

Please do send me a packet trace with the MLD packets and describing
what your application is doing in more detail if you still have a problem
with
this.

                        +-DLS
--0__=07BBE76ADFECEDFC8f9e8a93df938690918c07BBE76ADFECEDFC
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Takashi,<br>
<br>
<tt><font size="4">&gt;&gt;But there are still some problems.</font></tt><br>
<tt><font size="4">&gt;&gt;[MLDv2]</font></tt><br>
<tt><font size="4">&gt;&gt;1. After joining multicast address, MLDv2 listener report isn't issued &gt;&gt;immediately.</font></tt><br>
&gt;<br>
<tt><font size="4">&gt;This looks like a bug; it should send the first one immediately,</font></tt><br>
<tt><font size="4">&gt;and QRV-1 more at random intervals between 0 and MRC. It's adding</font></tt><br>
<tt><font size="4">&gt;the MRC random delay before sending the first one. Not critical,</font></tt><br>
<tt><font size="4">&gt;but I'll put a patch together in the next couple of days.</font></tt><br>
<br>
<tt><font size="4">I thought this was a bug, from a quick glance at the code, but I</font></tt><br>
<tt><font size="4">just looked some more and it already does the fix I had in mind.</font></tt><br>
<tt><font size="4">I also ran some tests, and I do see the advertisement immediately</font></tt><br>
<tt><font size="4">after an interface state change. That was with 2.6.0-test11bk8,</font></tt><br>
<tt><font size="4">but 2.4.22 has the same code for this piece.</font></tt><br>
<br>
In MLDv1 compatibility mode, interface state changes are not sent, but a<br>
&quot;leave group&quot; will result in an MLDv1 leave group message. So, I can't<br>
explain (or reproduce) this behaviour right now.<br>
<br>
Please do send me a packet trace with the MLD packets and describing<br>
what your application is doing in more detail if you still have a problem with<br>
this.<br>
<br>
				+-DLS<br>
</body></html>
--0__=07BBE76ADFECEDFC8f9e8a93df938690918c07BBE76ADFECEDFC--
