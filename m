From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 04/18] netfilter: ipset: Unified bitmap type generation
Date: Tue, 30 Apr 2013 09:49:21 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B720F@saturn3.aculab.com>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org> <1367259744-8922-5-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	<netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36798 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1759574Ab3D3IuU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 04:50:20 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30647-07 for <netdev@vger.kernel.org>;
 Tue, 30 Apr 2013 09:50:16 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1367259744-8922-5-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
> @@ -0,0 +1,265 @@
...
> +#define CONCAT(a, b)		a##b
> +#define TOKEN(a,b)		CONCAT(a, b)
> +
> +#define mtype_do_test		TOKEN(MTYPE, _do_test)
> +#define mtype_gc_test		TOKEN(MTYPE, _gc_test)
...
> +#define mtype			MTYPE

I'm not entirely sure what is being achieved by the above.
Either there ought to be a comment about what MTYPE might
be set to, or it is all pointless.

In any case names like CONCAT() and TOKEN() are likely
to be double definitions.

A similar namespace issue arises with REVISION_MIN/MAX.

	David
