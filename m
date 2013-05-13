From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with TSO
Date: Mon, 13 May 2013 15:10:10 -0700
Message-ID: <1368483010.13473.127.camel@edumazet-glaptop>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
	 <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
	 <1368479644.13473.121.camel@edumazet-glaptop>
	 <51915C7D.2000407@broadcom.com>
	 <1368481224.13473.124.camel@edumazet-glaptop>
	 <51915F77.5000405@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>, stable@vger.kernel.org
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51915F77.5000405@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-13 at 14:47 -0700, Nithin Nayak Sujir wrote:

> For the bug to occur, the fragment does not have to span a 4G boundary. If it is 
> within MSS bytes (9.6k) of a 4G boundary, it triggers the failure.
> 

Ah, that indeed can happen.

Thanks
