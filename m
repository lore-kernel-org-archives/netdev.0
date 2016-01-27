From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PULL] virtio: fixes, tests
Date: Wed, 27 Jan 2016 14:57:28 -0800
Message-ID: <CA+55aFzC6mopLkYYvuZNK8W510MpqgSuYwhjAAM-XeuAdEfs3A@mail.gmail.com>
References: <20160127211216-mutt-send-email-mst@redhat.com>
	<CA+55aFzypP2SDdX7y8MpZGKhmLJot=UT4i328CYBcNQsP2VU+Q@mail.gmail.com>
	<20160128001448-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jmarchan@redhat.com, KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Kamal Mostafa <kamal@canonical.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Junio C Hamano <gitster@pobox.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160128001448-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 27, 2016 at 2:15 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>>
>> Anyway, pulled. Just curious about how that thing happened.
>
> That's because apparently diffstat obeys orderfile rules:

Ugh. I guess that makes sense, but it's still very annoying for
something like a pull request, where now different people end up
having different diffstats. And the reason I never noticed it is that
likely there aren't that many people who use an orderfile.

I guess something like "-O /dev/null" in the pull-request would undo
it, but it is a bit annoying.

I've never actually met anybody (knowingly) that used that option. I
thought it was a Junio-only use case (it's been around forever as a
command line option, but the config file entry seems to be somewhat
recent and I wasn't even aware of it).

Adding Junio just as background to see what he thinks. Looks like the
diff.orderfile config option hits not just porcelain, but plumbing
too.

              Linus
