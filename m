From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] net/tulip: LAN driver for ULI M5261/M5263
Date: Sat, 20 Aug 2005 01:12:25 -0400
Message-ID: <4306BBB9.4060201@pobox.com>
References: <OF308CFA6C.C728268D-ON4825705F.00365A7A@uli.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Alan Cox <alan@redhat.com>,
	Clear.Zhang@uli.com.tw, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Emily.Jiang@uli.com.tw
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751039AbVHTFMc@vger.kernel.org>
To: Peer.Chen@uli.com.tw
In-Reply-To: <OF308CFA6C.C728268D-ON4825705F.00365A7A@uli.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peer.Chen@uli.com.tw wrote:
> Jeff:
> The attached file is the incremental patch to the original uli526x.c I send
> you first time,
> I modify the source according to your advice, thanks.
> 
> Signed-off-by: Peer Chen <Peer.Chen@uli.com.tw>
> (See attached file: patch_uli526x_inc)

Patch applied, thanks much.

I notice you removed the following code, rather than fixing it.  It is
OK to remove this code??


-       //add by clearzhang 2004/7/8
-       pci_read_config_dword(pdev,0x0,&configval);
-       m526x_id = configval;
-       if(configval == 0x526310b9)
-       {
-               //printk("is m5263\n");
-               pci_read_config_dword(pdev,0x0c,&configval);
-               configval = ((configval & 0xffff00ff) | 0x8000);
-               pci_write_config_dword(pdev,0x0c,configval);
-       }

Thanks,

	Jeff
