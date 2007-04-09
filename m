From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [iputils] Add documentation for the -l flag.
Date: Mon, 09 Apr 2007 13:16:27 +0900 (JST)
Message-ID: <20070409.131627.68439645.yoshfuji@linux-ipv6.org>
References: <460474E1.9070805@psc.edu>
	<11756226682486-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40966 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbXDIEP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 00:15:28 -0400
In-Reply-To: <11756226682486-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied two documentation patches.  Thanks.

In article <11756226682486-git-send-email-jheffner@psc.edu> (at Tue,  3 Apr 2007 13:51:07 -0400), John Heffner <jheffner@psc.edu> says:

> ---
>  doc/tracepath.sgml |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/doc/tracepath.sgml b/doc/tracepath.sgml
> index 71eaa8d..c0f308b 100644
> --- a/doc/tracepath.sgml
> +++ b/doc/tracepath.sgml
> @@ -15,6 +15,7 @@ traces path to a network host discovering MTU along this path</refpurpose>
>  <refsynopsisdiv>
>  <cmdsynopsis>
>  <command>tracepath</command>
> +<arg choice="opt">-l <replaceable/pktlen/</arg>
>  <arg choice="req"><replaceable/destination/</arg>
>  <arg choice="opt"><replaceable/port/</arg>
>  </cmdsynopsis>
> @@ -39,6 +40,18 @@ of UDP ports to maintain trace history.
>  </para>
>  </refsect1>
>  
> +<refsect1><title>OPTIONS</title>
> +<variablelist>
> + <varlistentry>
> +  <term><option/-l/</term>
> +  <listitem><para>
> +Sets the initial packet length to <replaceable/pktlen/ instead of
> +65536 for <command/tracepath/ or 128000 for <command/tracepath6/.
> +  </para></listitem>
> + </varlistentry>
> +</variablelist>
> +</refsect1>
> +
>  <refsect1><title>OUTPUT</title>
>  <para>
>  <literallayout>
> -- 
> 1.5.0.2.gc260-dirty
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
