From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 22/44] [IPV6]: Find option offset by type.
Date: Wed, 23 Aug 2006 13:22:06 -0400
Message-ID: <44EC8EBE.9080701@hp.com>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org> <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yo shfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.or
 g> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:30350 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S932262AbWHWR1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 13:27:14 -0400
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> This is a helper to search option offset from extension header which
> can carry TLV option like destination options header.
> Mobile IPv6 home address option will use it.
> Based on MIPL2 kernel patch.

> +	/* not_found */
> +	return -1;
> + bad:
> +	return -1;
> +}

You could change this to:

	/* not_found */
    bad:
	return -1;
    }

-Brian
