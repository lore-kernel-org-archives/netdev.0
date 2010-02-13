From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iputils: ping by mark
Date: Sat, 13 Feb 2010 11:21:16 -0500
Message-ID: <1266078076.6776.40.camel@bigi>
References: <1266074714.6776.28.camel@bigi>
	 <4B76C976.2060708@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-/KG3sQOTYMKaPvPEwzLY"
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:41532 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753Ab0BMQVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2010 11:21:20 -0500
Received: by qyk38 with SMTP id 38so1249344qyk.1
        for <netdev@vger.kernel.org>; Sat, 13 Feb 2010 08:21:19 -0800 (PST)
In-Reply-To: <4B76C976.2060708@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/KG3sQOTYMKaPvPEwzLY
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2010-02-14 at 00:47 +0900, YOSHIFUJI Hideaki wrote:
> Hello.
> 
> Okay, applied. Thank you.
> Could you give me patch for doc/ping.sgml as well, please?

Ok, here it is..

cheers,
jamal

--=-/KG3sQOTYMKaPvPEwzLY
Content-Disposition: attachment; filename="ping.sgml-mark"
Content-Type: text/plain; name="ping.sgml-mark"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 6e063d914a97c4b8160cb43a3129ea368b2a3fbb
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sat Feb 13 11:19:13 2010 -0500

    iputils: ping by mark doc update
    
    Update documentation for ping by-mark
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/doc/ping.sgml b/doc/ping.sgml
index 5995ea9..c895d7d 100644
--- a/doc/ping.sgml
+++ b/doc/ping.sgml
@@ -16,6 +16,7 @@
 <command>ping</command>
 <arg choice="opt"><option>-LRUbdfnqrvVaAB</option></arg>
 <arg choice="opt">-c <replaceable/count/</arg>
+<arg choice="opt">-m <replaceable/mark/</arg>
 <arg choice="opt">-i <replaceable/interval/</arg>
 <arg choice="opt">-l <replaceable/preload/</arg>
 <arg choice="opt">-p <replaceable/pattern/</arg>
@@ -76,6 +77,14 @@ The address is bound to one selected when <command/ping/ starts.
   </para></listitem>
  </varlistentry>
  <varlistentry>
+  <term><option>-m <replaceable/mark/</option></term>
+  <listitem><para>
+use <replaceable/mark/ to tag the packets going out. This is useful
+for variety of reasons within the kernel such as using policy
+routing to select specific outbound processing.
+  </para></listitem>
+ </varlistentry>
+ <varlistentry>
   <term><option><anchor id="ping.count">-c <replaceable/count/</option></term>
   <listitem><para>
 Stop after sending <replaceable/count/ ECHO_REQUEST

--=-/KG3sQOTYMKaPvPEwzLY--

