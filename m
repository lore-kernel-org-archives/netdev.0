From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 excessive PHY reset
Date: Fri, 16 Apr 2004 08:38:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416083836.A24723@electric-eye.fr.zoreil.com>
References: <407F6CC8.1060903@stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        shuchen@realtek.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Lutomirski <luto@stanford.edu>
Content-Disposition: inline
In-Reply-To: <407F6CC8.1060903@stanford.edu>; from luto@stanford.edu on Thu, Apr 15, 2004 at 10:19:04PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@stanford.edu> :
[r8169 phy issue with 2.6.5-mm5]
> -	mod_timer(timer, RTL8169_PHY_TIMEOUT);

I forgot a 'jiffies +' there. It is fixed in current Linus's tree.

--
Ueimor
