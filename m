From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH v3 net-next 8/8] net: qualcomm: add QCA7000 UART driver
Date: Fri, 21 Oct 2016 13:38:17 +0200
Message-ID: <acda56ec-75c2-9753-710e-d69b36f88095@i2se.com>
References: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
 <1476790054-27174-9-git-send-email-stefan.wahren@i2se.com>
 <20161018.143025.284251297276702898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, jslaby@suse.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161018.143025.284251297276702898.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 18.10.2016 um 20:30 schrieb David Miller:
> From: Stefan Wahren <stefan.wahren@i2se.com>
> Date: Tue, 18 Oct 2016 13:27:34 +0200
>
>> +void
>> +qca_tty_receive(struct tty_struct *tty, const unsigned char *cp, char *fp,
>> +		int count)
>> +{
>> +	struct qcauart *qca = tty->disc_data;
>> +	struct net_device_stats *n_stats = &qca->net_dev->stats;
>> +	int dropped = 0;
> Please order local variable declarations from longest to shortest line.

Even if the current second init depends on the first one?
