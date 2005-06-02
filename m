From: Gertjan van Wingerde <gwingerde@home.nl>
Subject: Re: [PATCH] ieee80211: Update generic definitions to latest specs.
Date: Thu, 02 Jun 2005 05:48:05 +0200
Message-ID: <429E8175.7010609@home.nl>
References: <429E1FAB.6080503@home.nl> <20050601143734.3b7a49ca@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050601143734.3b7a49ca@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>On Wed, 01 Jun 2005 22:50:51 +0200
>Gertjan van Wingerde <gwingerde@home.nl> wrote:
>
>  
>
>>Hi,
>>
>>Attached patch updates the definitions of the generic ieee80211 stack to 
>>the latest versions of the published 802.11x specification suite.
>>Please review and apply.
>>
>>Signed-off-by: Gertjan van Wingerde <gwingerde@home.nl>
>>
>>    
>>
>Could you change the elements that fix to be enum's instead of define's
>
>example:
>
>/* Management Frame Information Element Types */
>enum ieee80211_mfie {
>	MFIE_TYPE_SSID	= 0,
>	MFIE_TYPE_RATES = 1,
>	MFIE_TYPE_FH_SET= 2,
>...
>
Hi Stephen,

Well, my patch is really just an add-on to the existing code. Converting
to enums is really a follow-up patch that can be applied on top of this one.

I'm happy to produce a patch if everybody agrees.

Jeff, any opinions on this?

    Best regards,

       Gertjan.
