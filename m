From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Wed, 01 Jun 2011 21:11:42 -0700 (PDT)
Message-ID: <20110601.211142.557328157396419857.davem@davemloft.net>
References: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E568@EXDCVYMBSTM006.EQ1STM.local>
	<1306929701-22861-1-git-send-email-metze@samba.org>
	<1306929701-22861-2-git-send-email-metze@samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.name, gregkh@suse.de, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: metze@samba.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306929701-22861-2-git-send-email-metze@samba.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Metzmacher <metze@samba.org>
Date: Wed,  1 Jun 2011 14:01:41 +0200

> This avoids messages like this after suspend:
> 
>    cdc_ncm 2-1.4:1.6: no reset_resume for driver cdc_ncm?
>    cdc_ncm 2-1.4:1.7: no reset_resume for driver cdc_ncm?
>    cdc_ncm 2-1.4:1.6: usb0: unregister 'cdc_ncm' usb-0000:00:1d.0-1.4, CDC NCM
> 
> This is important for the Ericsson F5521gw GSM/UMTS modem.
> Otherwise modemmanager looses the fact that the cdc_ncm and cdc_acm devices
> belong together.
> 
> The cdc_ether module does the same.
> 
> Signed-off-by: Stefan Metzmacher <metze@samba.org>

Applied and queued up for -stable, thanks.
