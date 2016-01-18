From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: virtio pull for 4.5 (was Re: [PULL] virtio: barrier rework+fixes)
Date: Mon, 18 Jan 2016 11:07:53 -0800
Message-ID: <20160118190753.GC27825@linux-uzut.site>
References: <20160113182855-mutt-send-email-mst@redhat.com>
	<20160118152028-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: aquini@redhat.com, kvm@vger.kernel.org, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	alexander.duyck@gmail.com,
	virtualization@lists.linux-foundation.org, mingo@kernel.org,
	linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
	dbueso@suse.de, richard@nod.at, bjorn.andersson@sonymobile.com,
	rmk+kernel@arm.linux.org.uk, paulmck@linux.vnet.ibm.com,
	james.hogan@imgtec.com, arnd@arndb.de, julian.calaby@gmail.com,
	boqun.feng@gmail.com, schwidefsky@de.ibm.com,
	stefanha@redhat.com, tglx@linutronix.de, tony.luck@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, minchan@kernel.org,
	david.vrabel@citrix.com, joe@perches.com, akpm@linux-foundation.org,
	Linus Torvalds <torvalds@linux-foundation.org>, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160118152028-mutt-send-email-mst@redhat.com>
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

On Mon, 18 Jan 2016, Michael S. Tsirkin wrote:

>Hi Linus,
>Just making sure nothing's wrong with this pull request.
>If there's an issue, pls let me know!
>Thanks!
>
>On Wed, Jan 13, 2016 at 06:28:55PM +0200, Michael S. Tsirkin wrote:
>> The following changes since commit afd2ff9b7e1b367172f18ba7f693dfb62bdcb2dc:
>>
>>   Linux 4.4 (2016-01-10 15:01:32 -0800)
>>
>> are available in the git repository at:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
>>
>> for you to fetch changes up to 43e361f23c49dbddf74f56ddf6cdd85c5dbff6da:
>>
>>   checkpatch: add virt barriers (2016-01-12 20:47:08 +0200)
>>
>> ----------------------------------------------------------------
>> virtio: barrier rework+fixes
>>
>> This adds a new kind of barrier, and reworks virtio and xen
>> to use it.
>> Plus some fixes here and there.
>>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>>
>> ----------------------------------------------------------------
>>
>> Yes I know that the patch by Davidlohr Bueso has a typo in the subject :(
>>
>> Davidlohr Bueso (1):
>>       lcoking/barriers, arch: Use smp barriers in smp_store_release()

fyi this arrived in Linus' tree through Ingo's pull request for -tip:

https://lkml.org/lkml/2016/1/11/319
