From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [patch 1/6] s390: minor claw driver fix
Date: Wed, 22 Mar 2006 19:01:46 +0100
Message-ID: <20060322190146.115a7a01@localhost.localdomain>
References: <20060322162821.6ebd9af6@localhost.localdomain>
	<6e0cfd1d0603220742m80e553x461362297bf38e53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Martin Schwidefsky" <schwidefsky@googlemail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932197AbWCVSA1@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <6e0cfd1d0603220742m80e553x461362297bf38e53@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Mar 2006 16:42:14 +0100
"Martin Schwidefsky" <schwidefsky@googlemail.com> wrote:

> On 3/22/06, Frank Pavlic <fpavlic@de.ibm.com> wrote:
> > [patch 1/6] s390: minor claw driver fix
> >
> > From: Frank Pavlic <fpavlic@de.ibm.com>
> >
> >         use CONFIG_ARCH_S390X instead of CONFIG_64BIT in function dumpit .
> 
> Nack. CONFIG_ARCH_S390X doesn't exists anymore. It has been replaced
> by CONFIG_64BIT in 2.6.16.
> 
> --
> blue skies,
>   Martin

oh boy , you are absolutely right , did take the wrong kernel level for making this patch .
it was just before you did the upgrade to 2.6.16 :-(..

Jeff please don't apply this one ...the rest [2/6] - [6/6] is ok ...

Frank
