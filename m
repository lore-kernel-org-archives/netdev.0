From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sky2: Do not deadlock on sky2_hw_down
Date: Thu, 25 May 2017 23:58:30 -0400 (EDT)
Message-ID: <20170525.235830.986562840550889246.davem@davemloft.net>
References: <20170525105458.539dedba@xeon-e3>
        <CALH_86T3YW=VOCACJ+659GxZQQLtVafRpUTqQagWUdcsPDPH=A@mail.gmail.com>
        <20170525150502.4fe5c506@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jemele@gmail.com, jemele@acm.org, netdev@vger.kernel.org,
        jemele@google.com, mlindner@marvell.com,
        linux-kernel@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170525150502.4fe5c506@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 25 May 2017 15:05:02 -0700

> Ok, the issue is that lockdep is being stupid and thinking that
> seqcount's behave like locks.

Well.. they do.  That's why they have that annotation.
