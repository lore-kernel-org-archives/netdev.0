From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 6 Apr 2012 12:55:14 -0700
Message-ID: <CALCETrWJc83uy6Y+mLLMPKtxkBW2cWf4g1D+3M-0qgTfcnV1Bg@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406124921.5754e941.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20120406124921.5754e941.akpm@linux-foundation.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 12:49 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 29 Mar 2012 15:01:46 -0500
> Will Drewry <wad@chromium.org> wrote:
>
>> From: Andy Lutomirski <luto@amacapital.net>
>>
>> With this set, a lot of dangerous operations (chroot, unshare, etc)
>> become a lot less dangerous because there is no possibility of
>> subverting privileged binaries.
>>
>> This patch completely breaks apparmor. =A0Someone who understands (a=
nd
>> uses) apparmor should fix it or at least give me a hint.
>
> So [patch 2/15] fixes all this up?
>
> I guess we should join the two patches into one, to avoid a silly
> breakage window. =A0That means that John loses a brownie point, but w=
e
> can mention him in the changelog, include his signed-off-by:

Or just fix the commit message.  It no longer completely breaks
AppArmor.  It just causes execve to fail when PR_SET_NO_NEW_PRIVS is
set and AppArmor is in use.

--Andy
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
