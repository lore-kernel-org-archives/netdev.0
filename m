From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] NET: Add ezchip ethernet driver
Date: Tue, 23 Jun 2015 00:31:04 -0700 (PDT)
Message-ID: <20150623.003104.558693134575813076.davem@davemloft.net>
References: <1434263193-16877-1-git-send-email-noamc@ezchip.com>
	<1434465342-7412-1-git-send-email-noamc@ezchip.com>
	<CAF2d9jgQRatz_wL5+xk7fH=gAXTixb1yNVZGnenmKwR9RoSQLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noamc@ezchip.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alexey.Brodkin@synopsys.com,
	vgupta@synopsys.com, giladb@ezchip.com, cmetcalf@ezchip.com,
	talz@ezchip.com
To: maheshb@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF2d9jgQRatz_wL5+xk7fH=gAXTixb1yNVZGnenmKwR9RoSQLQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mahesh Bandewar <maheshb@google.com>
Date: Mon, 22 Jun 2015 10:45:15 -0700

> On Tue, Jun 16, 2015 at 7:35 AM, Noam Camus <noamc@ezchip.com> wrote:
>> @@ -0,0 +1,27 @@
>> +#
>> +# EZchip network device configuration
>> +#
>> +
>> +config NET_VENDOR_EZCHIP
>> +       bool "EZchip devices"
>> +       default y
>>
> Why this has to be included in the default build? Shouldn't it be
> either "m" or "N" by default?

It's a vendor guard, which are always enabled yes by default.
