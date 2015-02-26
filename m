From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] bridge: fix link notification skb size
 calculation to include vlan ranges
Date: Thu, 26 Feb 2015 06:13:40 -0800
Message-ID: <CAE4R7bCQQTW0CigHLxLCc+pvMfD-bkVHZWP_5HR5J7cbbke6rw@mail.gmail.com>
References: <1424937340-22115-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Siva Mannem <siva.mannem.lnx@gmail.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:63762 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932386AbbBZONl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:13:41 -0500
Received: by mail-qa0-f48.google.com with SMTP id dc16so7824429qab.7
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:13:41 -0800 (PST)
In-Reply-To: <1424937340-22115-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 11:55 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> my previous patch skipped vlan range optimizations during skb size
> calculations for simplicity.
>
> This incremental patch considers vlan ranges during
> skb size calculations. This leads to a bit of code duplication
> in the fill and size calculation functions. But, I could not find a
> prettier way to do this. will take any suggestions.
>
> Previously, I had reused the existing br_get_link_af_size size calculation
> function to calculate skb size for notifications. Reusing it this time
> around creates some change in behaviour issues for the usual
> .get_link_af_size callback.
>
> This patch adds a new br_get_link_af_size_filtered() function to
> base the size calculation on the incoming filter flag and include
> vlan ranges.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Reviewed-by: Scott Feldman <sfeldma@gmail.com>
