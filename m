From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Thu, 21 May 2009 09:36:11 -0600
Message-ID: <fa686aa40905210836x73e41651g9995ba813adec139@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<200905141438.23348.kosmo@semihalf.com>
	<fa686aa40905140700k3ca28ac0m74c9c161ad538abc@mail.gmail.com>
	<200905211034.39762.kosmo@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: Becky Bruce <Becky.Bruce@freescale.com>, Wolfgang Denk <wd@denx.de>,
	Detlev Zundel <dzu@denx.de>, John Rigby <jrigby@gmail.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Scott Wood <scottwood@freescale.com>
To: =?ISO-8859-2?Q?Piotr_Zi=EAcik?= <kosmo@semihalf.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <200905211034.39762.kosmo@semihalf.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

2009/5/21 Piotr Zi=EAcik <kosmo@semihalf.com>:
> Thursday 14 May 2009 16:00:33 Grant Likely wrote:
>> > MPC5121 support was added to drivers/net/fs_enet. MPC52xx uses
>> > drivers/net/fec_mpc52xx.c. Do you think that creating one universal
>> > driver from these two is now possible? You said that it should be easy,
>> > however you also said that cache coherency issues makes this imposible.
>>
>> Not impossible. =A0Hard.
>
> I thought a bit more about merging FEC drivers and I see one problem more.
> Driver fs_enet works with FEC's with own DMA engine and fec_mpc52xx.c uses
> BestComm. Integration of these two drivers will need a DMA abstraction la=
yer
> to keep everything clean. Unfortuanetly BestComm driver does not provide =
any
> abstraction - it only exports set of functions to deal with specific
> hardware: FEC and PATA.
>
> More #ifdef's will be needed to remove linking with BestComm driver if ke=
rnel
> will be compiled without 52xx support and resulting code will not be much
> better than existing one. Especially that new DMA abstraction layer proba=
bly
> will be quite complex.

If it looks too ugly, then just fork the driver.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
