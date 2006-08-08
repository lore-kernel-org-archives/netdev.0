From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH] Replace pci_module_init with pci_register_driver in drivers/net
Date: Mon, 7 Aug 2006 17:39:02 -0700
Message-ID: <4807377b0608071739y5ec9b324g7e1aa0e442f8c03b@mail.gmail.com>
References: <20060807222119.15758.72708.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:56957 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932461AbWHHAjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 20:39:03 -0400
Received: by nf-out-0910.google.com with SMTP id x37so29747nfc
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2006 17:39:02 -0700 (PDT)
To: "Pavel Roskin" <proski@gnu.org>
In-Reply-To: <20060807222119.15758.72708.stgit@dv.roinet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/7/06, Pavel Roskin <proski@gnu.org> wrote:
> -       pci_rc = pci_module_init(&vortex_driver);
> +       pci_rc = pci_register_driver(&vortex_driver);
>         eisa_rc = vortex_eisa_init();

not sure why this *function name change* really matters, but
technically I'm okay with the e100/e1000/ixgb changes. (Jesse heads
off to change his out of tree driver kcompat.h)

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
