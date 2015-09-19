From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 4/7] bridge: define some min/max ageing time
 constants we'll use next
Date: Sat, 19 Sep 2015 10:20:59 -0700
Message-ID: <CAE4R7bDeXC0+P5zmgiD+MfQ_6hzujdS-+PBh6d6ox7-pNoSuag@mail.gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-5-git-send-email-sfeldma@gmail.com> <20150919064507.GD2067@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33111 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbbISRVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 13:21:19 -0400
Received: by obbbh8 with SMTP id bh8so57844922obb.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 10:21:19 -0700 (PDT)
In-Reply-To: <20150919064507.GD2067@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 11:45 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Sep 18, 2015 at 09:55:48PM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> include/linux/if_bridge.h |    4 ++++
>> 1 file changed, 4 insertions(+)
>>
>>diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
>>index dad8b00..6cc6dbc 100644
>>--- a/include/linux/if_bridge.h
>>+++ b/include/linux/if_bridge.h
>>@@ -46,6 +46,10 @@ struct br_ip_list {
>> #define BR_LEARNING_SYNC      BIT(9)
>> #define BR_PROXYARP_WIFI      BIT(10)
>>
>>+/* values as per ieee8021QBridgeFdbAgingTime */
>>+#define BR_MIN_AGEING_TIME    (10 * HZ)
>>+#define BR_MAX_AGEING_TIME    (1000000 * HZ)
>
> I think that a bridge patch checking against these values should be
> introduced along with these values, in the same patchset

I need the MIN value for this patchset in rocker's ageing timer, so
it's introduced here.  MIN/MAX will be used again in follow-on patch
Prem is going to send to range check user input.
