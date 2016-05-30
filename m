From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH iproute2 net-next 2/5] bridge: add json support for bridge
 vlan show
Date: Mon, 30 May 2016 09:43:07 +0900
Message-ID: <92ec8efe-8627-2d3a-736d-4fadce3a8bd8@lab.ntt.co.jp>
References: <1464410236-65044-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:59618 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbcE3BIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 21:08:07 -0400
In-Reply-To: <1464410236-65044-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/05/28 13:37, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> $bridge -c vlan show
> port	vlan ids
> swp1	 1 PVID Egress Untagged
> 	 10-13
> 
> swp2	 1 PVID Egress Untagged
> 	 10-13
> 
> br0	 1 PVID Egress Untagged
> 
> $bridge -j vlan show
> {
>     "swp1": [{
>             "vlan": 1,
>             "flags": "PVID Egress Untagged"

Shouldn't we split flags?

    "swp1": [{
            "vlan": 1,
            "flags": [
                "PVID",
                "Egress Untagged"
            ]
        }
