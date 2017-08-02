From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: Demote messages about fw flags size to info
Date: Wed, 02 Aug 2017 07:46:48 +0300
Message-ID: <1501649208.2588.55.camel@coelho.fi>
References: <20170721145147.7572-1-jprvita@endlessm.com>
         <1500894086.20057.12.camel@intel.com>
         <CAOcMMifW4mVPj1TVkzQPdvT0YO6p1DUObNinzWv2_ZtCbfk9Mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linuxwifi <linuxwifi@intel.com>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "jprvita@gmail.com" <jprvita@gmail.com>,
        "Berg, Johannes" <johannes.berg@intel.com>,
        "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux@endlessm.com" <linux@endlessm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@endlessm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOcMMifW4mVPj1TVkzQPdvT0YO6p1DUObNinzWv2_ZtCbfk9Mg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi João Paulo,


On Tue, 2017-08-01 at 15:58 -0700, João Paulo Rechi Vita wrote:
> Hello Luca,
> 
> On Mon, Jul 24, 2017 at 4:01 AM, Coelho, Luciano
> <luciano.coelho@intel.com> wrote:
> > On Fri, 2017-07-21 at 07:51 -0700, João Paulo Rechi Vita wrote:
> 
> (...)
> 
> > > Currently these messages are presented to the user during boot if there
> > > is no bootsplash covering the console, sometimes even if the boot splash
> > > is enabled but has not started yet by the time this message is shown.
> > > 
> 
> I should have provided another piece of information here: all of this
> happens even when booting with the 'quiet' kernel parameter.

Oh, okay, that's annoying.


> > This specific case is harmless, but I'd rather keep this message as an
> > error, because in other situations it could lead to unexpected
> > behavioir, so I prefer to keep it very visible.
> > 
> > 
> 
> I see your point, and I understand the purpose of these messages. I'm
> wondering if perhaps having them at the warning level would give them
> enough visibility, while still keeping a clean boot process to the end
> user. If so, I can send an updated patch.
> 
> Thanks for your reply and for pointing to the fix for the root cause
> of that message.

Sure, I agree it's better to make it use IWL_WARN(), which will generate
a dev_warn() instead of a dev_err().


--
Cheers,
Luca.
