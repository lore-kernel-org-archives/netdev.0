From: Neil Jerram <Neil.Jerram@metaswitch.com>
Subject: RE: [net-next v3 2/3] UAPI: add MPLS label stack definition
Date: Tue, 25 Feb 2014 09:53:40 +0000
Message-ID: <F6885DC5CBE92C4BB4D654841E63A30FD7DD5F03@ENFIRHMBX1.datcon.co.uk>
References: <1393244920-15903-1-git-send-email-sw@simonwunderlich.de>
 <1393244920-15903-3-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Simon Wunderlich' <sw@simonwunderlich.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from enfirhets1.metaswitch.com ([192.91.191.166]:21559 "EHLO
	ENFIRHETS1.metaswitch.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaBYJ7G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 04:59:06 -0500
In-Reply-To: <1393244920-15903-3-git-send-email-sw@simonwunderlich.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [net-next v3 2/3] UAPI: add MPLS label stack definition
[...]
> +/* Reference: RFC 5462, RFC 3032
> + *
> + *  0                   1                   2                   3
> + *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |                Label                  | TC  |S|       TTL     |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *
> + *	Label:  Label Value, 20 bits
> + *	TC:     Traffic Class field, 3 bits
> + *	S:      Bottom of Stack, 1 bit
> + *	TTL:    Time to Live, 8 bits
> + */
> +
> +struct mpls_label_stack {
> +	__be32 entry;
> +};

The "label stack" name isn't quite right as this struct describes just one entry in an MPLS label stack.  Perhaps one of the following instead?
- mpls_label
- mpls_label_entry
- mpls_label_stack_entry
- mpls_lse.

I suppose mpls_label_stack_entry is the most pedantically correct (and is what RFC 3032 says); but for conciseness and general readability I favour mpls_label.

Regards,
      Neil
