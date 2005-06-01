From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ieee80211: Update generic definitions to latest specs.
Date: Wed, 1 Jun 2005 14:37:34 -0700
Message-ID: <20050601143734.3b7a49ca@dxpl.pdx.osdl.net>
References: <429E1FAB.6080503@home.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gertjan van Wingerde <gwingerde@home.nl>
In-Reply-To: <429E1FAB.6080503@home.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 01 Jun 2005 22:50:51 +0200
Gertjan van Wingerde <gwingerde@home.nl> wrote:

> Hi,
> 
> Attached patch updates the definitions of the generic ieee80211 stack to 
> the latest versions of the published 802.11x specification suite.
> Please review and apply.
> 
> Signed-off-by: Gertjan van Wingerde <gwingerde@home.nl>
> 
Could you change the elements that fix to be enum's instead of define's

example:

/* Management Frame Information Element Types */
enum ieee80211_mfie {
	MFIE_TYPE_SSID	= 0,
	MFIE_TYPE_RATES = 1,
	MFIE_TYPE_FH_SET= 2,
...
