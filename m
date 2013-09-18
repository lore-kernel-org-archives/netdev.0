From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 002/007] WAN Drivers: Update farsync driver and
 introduce fsflex driver
Date: Wed, 18 Sep 2013 08:25:21 -0700
Message-ID: <1379517921.1787.24.camel@joe-AO722>
References: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA1@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Dermot Smith <dermot.smith@farsite.com>
To: Kevin Curtis <Kevin.Curtis@farsite.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA1@SOLO.hq.farsitecommunications.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-18 at 11:11 +0100, Kevin Curtis wrote:
> Farsite Communications FarSync driver update
[]
> diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/uss_cmn.h linux-3.10.1_new/drivers/net/wan/uss_cmn.h

> +typedef enum _USS_COMMANDS {

I think this code would be more linux style
without all the typedefs

> +typedef struct {
[]
> +} FLEX_SERCONF, *PFLEX_SERCONF;

> +typedef struct {
[]
> +} FLEX_CARD_INFO, *PFLEX_CARD_INFO;    /* sizeof(FLEX_CARD_INFO) = 128 */

> +typedef struct {
[]
> +} FLEX_USB_STATS, *PFLEX_USB_STATS;

> +typedef struct _INTERFACE_RECORD {
[]
> +} IR, *PIR;

> +typedef struct _INTERFACE_RECORD_EX {
[]
> +} IREX, *PIREX;
