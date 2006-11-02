From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 2 Nov 2006 18:15:55 -0500
Message-ID: <43e72e890611021515y6d705743t28fab2f4440d8a78@mail.gmail.com>
References: <20061102193839.4884ae56@logostar.upir.cz>
	 <C86180A8C204554D8A3323D8F6B0A29F018B5E78@dhost002-46.dex002.intermedia.net>
	 <20061102144833.6a161b2b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Simon Barber" <simon@devicescape.com>,
	"Jiri Benc" <jbenc@suse.cz>, "Sven-Haegar Koch" <haegar@sdinet.de>,
	"Christoph Hellwig" <hch@infradead.org>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:28861 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1752775AbWKBXQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 18:16:01 -0500
Received: by ug-out-1314.google.com with SMTP id m3so272292ugc
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2006 15:15:59 -0800 (PST)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20061102144833.6a161b2b@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/2/06, Stephen Hemminger <shemminger@osdl.org> wrote:

> Please have Ethernet (and wireless) devices show up as eth%d. For the
> master device, choose something else (mac%d ?).

If ultimately we're going to make wireless devices, as John puts it,
"1st class citizens" by making 802.11 a full protocol we should just
start sticking to a new convention. Before when we didn't have any
softmac drivers in the kernel ethX made sense, with softmac this isn't
so clear, but with 802.11 as a full protocol perhaps wlanX will
finally make perfect sense. For the master device yes, how about mac%d
as its there do 802.11 MAC management.
