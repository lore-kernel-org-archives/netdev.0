From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] SuperH IrDA: correct Baud rate error correction
Date: Thu, 18 Nov 2010 16:41:50 -0800
Message-ID: <20101118164150.22aa7e16@nehalam>
References: <20101119012402.43e9aa61@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Kuninori Morimoto <morimoto.kuninori@renesas.com>,
	irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicolas Kaiser <nikai@nikai.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101119012402.43e9aa61@absol.kitzblitz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Nov 2010 01:24:02 +0100
Nicolas Kaiser <nikai@nikai.net> wrote:

>  	u32 rate_err_array[] = {
> -		0000, 0625, 1250, 1875,
> +		   0,  625, 1250, 1875,
>  		2500, 3125, 3750, 4375,
>  		5000, 5625, 6250, 6875,
>  		7500, 8125, 8750, 9375,

While you are at it make that table const.
