From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] atm: solos-pci: constify attribute_group structures
Date: Wed, 02 Aug 2017 16:53:51 -0700 (PDT)
Message-ID: <20170802.165351.424790560739401085.davem@davemloft.net>
References: <20170801235747.GA14034@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801235747.GA14034@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Tue, 1 Aug 2017 19:57:47 -0400

> Functions working with attribute_groups provided by <linux/sysfs.h>
> work with const attribute_group. These attribute_group structures do not
> change at runtime so mark them as const.
> 
> File size before:
>  text      data     bss     dec     hex filename
>  35740    28424     832   64996    fde4 drivers/atm/solos-pci.o
> 
> File size after:
>  text      data     bss     dec     hex filename
>  35932    28232     832   64996    fde4 drivers/atm/solos-pci.o
> 
> This change was made with the help of Coccinelle.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied.
