From: jacob jacob <opstkusr@gmail.com>
Subject: Re: PCI passthrough of 40G ethernet interface
	(Openstack/KVM)
Date: Thu, 19 Mar 2015 19:37:47 -0400
Message-ID: <CA+AkT2ikg0oL64zaALP+wPtPLN3-+on7_4PqV6BnpVyB8PTsyg@mail.gmail.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>
	<jpg8uf2ghln.fsf@redhat.com>
	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>
	<jpgtwxpvk5x.fsf@redhat.com>
	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>
	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>
	<jpg1tko7qwb.fsf@redhat.com>
	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>
	<jpglhiw4tal.fsf@redhat.com> <jpgk2yewcpt.fsf@redhat.com>
	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
	<CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
	<CAP-MU4Pfv9W9FgaLxwOac3LnSJMxWcbYP4Pq43YjcJ9AWAamvQ@mail.gmail.com>
	<550A85B3.4070703@redhat.com>
	<CA+AkT2gHKtz2bKSf2FB+3+XkDidBnUDQSZy_KPb1y-MG+QnSiw@mail.gmail.com>
	<CAP-MU4MTf+kRvvBZYDdsJbDjA1ATe-4zuBCKoCyKpboB9+cD6g@mail.gmail.com>
	<CA+AkT2hYLu8aC2sRnmqyzLdrN7pncTL5ELxg_+OxCg9ZqQvpeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>, Bandan Das <bsd@redhat.com>,
	Stefan Assmann <sassmann@redhat.com>
To: Shannon Nelson <shannon.nelson@intel.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <CA+AkT2hYLu8aC2sRnmqyzLdrN7pncTL5ELxg_+OxCg9ZqQvpeQ@mail.gmail.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 19, 2015 at 5:53 PM, jacob jacob <opstkusr@gmail.com> wrote:
> On Thu, Mar 19, 2015 at 5:42 PM, Shannon Nelson
> <shannon.nelson@intel.com> wrote:
>> On Thu, Mar 19, 2015 at 2:04 PM, jacob jacob <opstkusr@gmail.com> wrote:
>>> I have updated to latest firmware and still no luck.
>>
>> [...]
>>
>>> [   61.554132] i40e 0000:00:06.0 eth2: the driver failed to link
>>> because an unqualified module was detected.     <<<<<<<<<<<<<<<<<<<<
>>> [   61.555331] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready
>>>
>>
>> So I assume you're getting traffic on the other port and it doesn't
>> complain about "unqualified module"?  Does the problem move if you
>> swap the cables?  The usual problem here is a QSFP connector that
>> isn't compatible with the NIC.  I don't have a pointer handy to the
>> official list, but you should be able to get that from your NIC
>> supplier.
>
> No. That is not the case.
>
> The traffic counters are for the dpdk test run which uses igb_uio driver.
>
> As i mentioned earlier, have tried all combinations of cable, pci slot
> , card etc to isolate any hw issues.

Everything works fine on the host and hence the
modules are verified to be working.
The issue is seen only when the device is passed through to a VM
running on the same host.
