From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Wed, 16 Apr 2014 07:37:26 -0700
Message-ID: <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vivek Goyal <vgoyal@redhat.com>, Tejun Heo <tj@kernel.org>,
	Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, Simo Sorce <ssorce@redhat.com>,
	cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140416.085743.1614257692560892039.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 5:57 AM, David Miller <davem@davemloft.net> wrote:
>
> Please, just stop.

No.

This thread is proposing an ABI.  This means that, if the ABI ends up
in Linus's kernel, then it has to be supported forever.  Now is the
time to find and fix any issues with it before they become much harder
to fix.

This ABI is especially tricky because programs will use it even if
they don't explicitly try to.  So just adding the ABI may break
existing assumptions that are relevant to security or correctness.

--Andy
