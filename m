From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2] Bluetooth: hidp: using strlcpy instead of strncpy,
 also beautify code.
Date: Thu, 09 May 2013 16:48:38 +0800
Message-ID: <518B62E6.1040905@asianux.com>
References: <518906A8.7060708@asianux.com> <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com> <5189A417.503@asianux.com> <5189C7C6.8090408@asianux.com> <alpine.LNX.2.00.1305091041140.23038@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	andrei.emeltchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1305091041140.23038-ztGlSCb7Y1iN3ZZ/Hiejyg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/09/2013 04:42 PM, Jiri Kosina wrote:
> On Wed, 8 May 2013, Chen Gang wrote:
> 
>> > 
>> > For NUL terminated string, need always let it ended by zero.
>> > 
>> > Since have already called memcpy() to initialize 'ci', so need not
>> > redundent initializations.
>> > 
>> > Better use ''if(session->hid) {} else if(session->input) {}'' instead
>> > of ''if(session->hid) {}; if(session->input) {};''
>> > 
>> > Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
> Makes sense.
> 
> Acked-by: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
> 
> Gustavo, going to take this, please?
> 
> -- Jiri Kosina SUSE Labs
> 

Thanks, and also help to fix the spelling: redundent -> redundant.
(if need let me send patch v3, please reply to tell me, thanks)


-- 
Chen Gang

Asianux Corporation
