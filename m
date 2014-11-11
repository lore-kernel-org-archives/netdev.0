From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/1] linux-wireless: Added psk in struct
 cfg80211_connect_params needed for offloading 4way handshake to driver
Date: Tue, 11 Nov 2014 11:38:58 +0100
Message-ID: <1415702338.2163.5.camel@sipsolutions.net>
References: <DF163EE1A432BF4BBE6B2088220663A67437BD@SJEXCHMB06.corp.ad.broadcom.com>
		 <1415698161.2163.0.camel@sipsolutions.net> <5461DCC9.5050702@broadcom.com>
	 <1415700220.2163.3.camel@sipsolutions.net> <5461E67E.7010408@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gautam (Gautam Kumar) Shukla" <gautams@broadcom.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jithu Jance <jithu@broadcom.com>,
	Sreenath S <sreenats@broadcom.com>,
	Vladimir Kondratiev <vkondrat@qca.qualcomm.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5461E67E.7010408@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-11-11 at 11:35 +0100, Arend van Spriel wrote:

> What did pop up is the wiphy flags vs. nl80211 feature flags. When that
> comes up it looks like 'potAtoes, potaetoes' to me.
> 
> So is there are clear design rule for when to use which flag. For me the
> wiphy object represents the device/firmware and 4-way handshake offload
> support is determined by what the device/firmware supports.

There are three types of flags:

 * wiphy flag attributes - deprecated as far as I'm concerned
 * wiphy nl80211 feature flags - much easier to use in kernel (and
userspace)
 * nl80211 protocol flags - only one exists
                            (NL80211_PROTOCOL_FEATURE_SPLIT_WIPHY_DUMP)

johannes
