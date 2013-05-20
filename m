From: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3] Bluetooth: hidp: using strlcpy instead of strncpy,
 also beautify code.
Date: Mon, 20 May 2013 18:52:24 -0300
Message-ID: <20130520215224.GE17712@joana>
References: <518906A8.7060708@asianux.com>
 <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com>
 <5189A417.503@asianux.com>
 <5189C7C6.8090408@asianux.com>
 <alpine.LNX.2.00.1305091041140.23038@pobox.suse.cz>
 <51904ACF.6010904@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	andrei.emeltchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51904ACF.6010904-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Chen,

* Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org> [2013-05-13 10:07:11 +0800]:

> 
> For NUL terminated string, need always let it ended by zero.
> 
> Since have already called memcpy() to initialize 'ci', so need not
> redundant initialization.
> 
> Better use ''if(session->hid) {} else if(session->input) {}"" instead
> of ''if(session->hid) {}; if(session->input) {};''
> 
> Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
> ---
>  net/bluetooth/hidp/core.c |   14 ++++----------
>  1 files changed, 4 insertions(+), 10 deletions(-)

Sorry for the big delay on this, patches has now been applied to
bluetooth-next. Thanks all.

	Gustavo
