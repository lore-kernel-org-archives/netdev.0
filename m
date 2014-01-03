From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: coding style fixes
Date: Fri, 03 Jan 2014 13:50:29 +0400
Message-ID: <52C687E5.5020100@cogentembedded.com>
References: <201312310325.21951.sergei.shtylyov@cogentembedded.com> <20140102.193407.23280653408847634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140102.193407.23280653408847634.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03-01-2014 4:34, David Miller wrote:

>> @@ -1952,8 +1949,8 @@ static void sh_eth_tx_timeout(struct net
>>   	netif_stop_queue(ndev);
>>
>>   	if (netif_msg_timer(mdp))
>> -		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x,"
>> -	       " resetting...\n", ndev->name, (int)sh_eth_read(ndev, EESR)=
);
>> +		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x, resett=
ing...\n"
>> +			ndev->name, (int)sh_eth_read(ndev, EESR));
>>
>>   	/* tx_errors count up */
>>   	ndev->stats.tx_errors++;

> You did not build test this.

    Hm, I was sure I did but you're right...

> drivers/net/ethernet/renesas/sh_eth.c: In function =A1sh_eth_tx_timeo=
ut=A2:
> drivers/net/ethernet/renesas/sh_eth.c:1953:4: error: expected =A1)=A2=
 before =A1ndev=A2
> drivers/net/ethernet/renesas/sh_eth.c:1953:4: warning: format =A1%s=A2=
 expects a matching =A1char *=A2 argument [-Wformat]
> drivers/net/ethernet/renesas/sh_eth.c:1953:4: warning: format =A1%x=A2=
 expects a matching =A1unsigned int=A2 argument [-Wformat]

    Missing comma, apparently. :-(

WBR, Sergei

