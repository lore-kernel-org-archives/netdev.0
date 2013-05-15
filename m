From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with TSO
Date: Wed, 15 May 2013 08:23:43 -0700
Message-ID: <1368631423.4519.32.camel@edumazet-glaptop>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
	 <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
	 <1368479644.13473.121.camel@edumazet-glaptop>
	 <51915C7D.2000407@broadcom.com>
	 <1368481224.13473.124.camel@edumazet-glaptop>
	 <51915F77.5000405@broadcom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7236@saturn3.aculab.com>
	 <1368543869.12268.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7237@saturn3.aculab.com>
	 <1368548345.12268.76.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7239@saturn3.aculab.com>
	 <1368630754.3768.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	davem@davemloft.net, netdev@vger.kernel.org, stable@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1368630754.3768.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-15 at 08:12 -0700, Michael Chan wrote:

> 
> We will discard the packet if that happens.  I think the probabilty is
> very small.

Data corruption means the content of the packet was mangled on the wire,
or was it a more serious issue, like a tx queue hang ?
