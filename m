From: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v2] Bluetooth: hidp: using strlcpy instead of strncpy,
 also beautify code.
Date: Thu, 9 May 2013 10:42:15 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1305091041140.23038@pobox.suse.cz>
References: <518906A8.7060708@asianux.com> <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com> <5189A417.503@asianux.com> <5189C7C6.8090408@asianux.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	andrei.emeltchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5189C7C6.8090408-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 8 May 2013, Chen Gang wrote:

> 
> For NUL terminated string, need always let it ended by zero.
> 
> Since have already called memcpy() to initialize 'ci', so need not
> redundent initializations.
> 
> Better use ''if(session->hid) {} else if(session->input) {}'' instead
> of ''if(session->hid) {}; if(session->input) {};''
> 
> Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>

Makes sense.

Acked-by: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>

Gustavo, going to take this, please?

-- 
Jiri Kosina
SUSE Labs
