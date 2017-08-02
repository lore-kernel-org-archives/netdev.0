From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] atm: adummy: constify attribute_group structure
Date: Wed, 02 Aug 2017 16:53:44 -0700 (PDT)
Message-ID: <20170802.165344.1436084142194668583.davem@davemloft.net>
References: <20170801235738.GA13517@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801235738.GA13517@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Tue, 1 Aug 2017 19:57:38 -0400

> Functions working with attribute_groups provided by <linux/sysfs.h>
> work with const attribute_group. These attribute_group structures do not
> change at runtime so mark them as const.
> 
> File size before:
>  text      data     bss     dec     hex filename
>  2033      1448       0    3481     d99 drivers/atm/adummy.o
> 
> File size after:
>  text      data     bss     dec     hex filename
>  2129      1352       0    3481     d99 drivers/atm/adummy.o
> 
> This change was made with the help of Coccinelle.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied.
