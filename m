From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: replace ds with ps where possible
Date: Fri, 29 Apr 2016 10:55:26 -0400
Message-ID: <877ffgmplt.fsf@ketchup.mtl.sfl>
References: <1461893046-28200-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20160429130645.GG4053@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160429130645.GG4053@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Thu, Apr 28, 2016 at 09:24:06PM -0400, Vivien Didelot wrote:
>> From: Andrew Lunn <andrew@lunn.ch>
>> 
>> The dsa_switch structure ds is actually needed in very few places,
>> mostly during setup of the switch. The private structure ps is however
>> needed nearly everywhere. Pass ps, not ds internally.
>> 
>> [vd: rebased Andrew's patch.]
>
> Hi Vivien
>
> Thanks for picking up this patch and rebasing it.
>
> I would generally put comments like that bellow the ---. They don't
> need to be in the commit log.

I've seen that '[<initials-or-firstname>: <message>]' is often used to
inject notes in the message, but that might not be a standard.

Thanks for the note,

       Vivien
