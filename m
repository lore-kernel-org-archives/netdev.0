From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Wed, 24 Feb 2016 09:58:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D41109A1B@AcuExch.aculab.com>
References: <56CC7848.2000704@solarflare.com>
	<CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<CAEh+42iCxKb+OsMqR51nvzeCr_7n3WLncCaWNuctW7FbYijmCQ@mail.gmail.com>
 <20160223.132458.488971277682238141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "tom@herbertland.com" <tom@herbertland.com>,
	"ecree@solarflare.com" <ecree@solarflare.com>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: 'David Miller' <davem@davemloft.net>,
	"jesse@kernel.org" <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:61228 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbcBXKBn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 05:01:43 -0500
In-Reply-To: <20160223.132458.488971277682238141.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 23 February 2016 18:25
> 
> From: Jesse Gross <jesse@kernel.org>
> Date: Tue, 23 Feb 2016 09:31:09 -0800
> 
> > Most OSs (including Linux with connected TCP sockets) use non-zero IP
> > IDs so requiring this would effectively disable GRO.
> 
> +1
> 
> Any OS that wants to work with SLHC, as I mentioned, has to emit
> monotonically increasing IP ID values in all packets, even those with
> DF set.

Doesn't that leak a lot of info about the sending system?
ISTR one OS deliberately randomising the IP ID values in order
to avoid giving out information about the number of packets being sent.

	David
