From: Pragati Dhingra <pragatidhingra@yahoo.com>
Subject: CONFIG_NET_FASTROUTE in 8390
Date: Thu, 17 Jun 2004 07:16:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617141626.60307.qmail@web90108.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-935360949-1087481786=:58766"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-935360949-1087481786=:58766
Content-Type: text/plain; charset=us-ascii

Hi,
 
I was browsing through the fast routing code for 8390 (the link to which I got from kernel configuration help file)
 
In e8390_fast_route function, 
 
struct rtable *rt;
 
and for indriver lookup,
 

 if (rt == NULL ||
     ((u16*)&iph->daddr)[0] != ((u16*)&rt->key.dst)[0] ||
     ((u16*)&iph->daddr)[1] != ((u16*)&rt->key.dst)[1] ||
     ((u16*)&iph->saddr)[0] != ((u16*)&rt->key.src)[0] ||
     ((u16*)&iph->saddr)[1] != ((u16*)&rt->key.src)[1] ||
     rt->u.dst.obsolete)
 
struct rtable does not have a member named key and I could not locate a #define which would define "key". 
 
Can you pls tell me what is key refering to and how? (ofcourse it needs to refer to destination address in route table entry, but how is what is really puzzling me)
 
Thanks and regards,
Pragati

		
---------------------------------
Do you Yahoo!?
New and Improved Yahoo! Mail - 100MB free storage!
--0-935360949-1087481786=:58766
Content-Type: text/html; charset=us-ascii

<DIV>Hi,</DIV>
<DIV>&nbsp;</DIV>
<DIV>I was browsing through the fast routing code for 8390 (the link to which I got from kernel configuration help file)</DIV>
<DIV>&nbsp;</DIV>
<DIV>In e8390_fast_route function, </DIV>
<DIV>&nbsp;</DIV>
<DIV>
<DIV>struct rtable *rt;</DIV>
<DIV>&nbsp;</DIV>
<DIV>and for indriver lookup,</DIV>
<DIV>&nbsp;</DIV></DIV>
<DIV>&nbsp;if (rt == NULL ||<BR>&nbsp;&nbsp;&nbsp;&nbsp; ((u16*)&amp;iph-&gt;daddr)[0] != ((u16*)&amp;rt-&gt;key.dst)[0] ||<BR>&nbsp;&nbsp;&nbsp;&nbsp; ((u16*)&amp;iph-&gt;daddr)[1] != ((u16*)&amp;rt-&gt;key.dst)[1] ||<BR>&nbsp;&nbsp;&nbsp;&nbsp; ((u16*)&amp;iph-&gt;saddr)[0] != ((u16*)&amp;rt-&gt;key.src)[0] ||<BR>&nbsp;&nbsp;&nbsp;&nbsp; ((u16*)&amp;iph-&gt;saddr)[1] != ((u16*)&amp;rt-&gt;key.src)[1] ||<BR>&nbsp;&nbsp;&nbsp;&nbsp; rt-&gt;u.dst.obsolete)</DIV>
<DIV>&nbsp;</DIV>
<DIV>struct rtable does not have a member named key and I could not locate a #define which would&nbsp;define "key". </DIV>
<DIV>&nbsp;</DIV>
<DIV>Can you pls tell me what is key refering to and how? (ofcourse it needs to refer to destination address in route table entry, but how is what is really puzzling me)</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks and regards,</DIV>
<DIV>Pragati</DIV><p>
		<hr size=1>Do you Yahoo!?<br>
<a href="http://us.rd.yahoo.com/mail/taglines/*http://promotions.yahoo.com/new_mail/static/efficiency.html">New and Improved Yahoo! Mail</a> - 100MB free storage!
--0-935360949-1087481786=:58766--
