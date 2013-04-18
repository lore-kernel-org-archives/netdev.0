From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use lockless genl.
Date: Thu, 18 Apr 2013 14:24:41 -0700
Message-ID: <CALnjE+oh5pSUSiKQJ6X2ZkJaArXzEw+2Csax9ixGkuk71LR0Rw@mail.gmail.com>
References: <1366319812-16625-1-git-send-email-pshelar@nicira.com>
	<20130418.171846.2215092862903415243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130418.171846.2215092862903415243.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 2:18 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 18 Apr 2013 14:16:52 -0700
>
>> OVS locking was recently changed to have private OVS lock which
>> simplified overall locking.  Therefore there is no need to have
>> another global genl lock to protect OVS data structures.  Following
>> patch uses of lockless genl family for OVS.  This also allows
>> more granual OVS locking using ovs_mutex for protecting OVS data
>> structures, which gives more consurrencey.  E.g multiple genl
>> operations OVS_PACKET_CMD_EXECUTE can run in parallel, etc.
>>
>> Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>
> Three problems with this submission:
>
> 1) When you resubmit a patch that's part of a series, you must repost
>    the entire series.
>
> 2) When you post a new version of a patch, you must list (after the
>    "---" delimiter) what has changed in this version.
>
> 3) When you post a new version of a patch, you must indicate this by
>    putting "[PATCH v2 ...] ...", for example, in the Subject line.

I thought I just need to post patch that was changed. Let me send
updated series again.
