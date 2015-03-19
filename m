From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Thu, 19 Mar 2015 14:42:17 -0700
Message-ID: <CAP-MU4MTf+kRvvBZYDdsJbDjA1ATe-4zuBCKoCyKpboB9+cD6g@mail.gmail.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>
	<jpg8uf2ghln.fsf@redhat.com>
	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>
	<jpgtwxpvk5x.fsf@redhat.com>
	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>
	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>
	<jpg1tko7qwb.fsf@redhat.com>
	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>
	<jpglhiw4tal.fsf@redhat.com>
	<jpgk2yewcpt.fsf@redhat.com>
	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
	<CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
	<CAP-MU4Pfv9W9FgaLxwOac3LnSJMxWcbYP4Pq43YjcJ9AWAamvQ@mail.gmail.com>
	<550A85B3.4070703@redhat.com>
	<CA+AkT2gHKtz2bKSf2FB+3+XkDidBnUDQSZy_KPb1y-MG+QnSiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefan Assmann <sassmann@redhat.com>, Bandan Das <bsd@redhat.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: jacob jacob <opstkusr@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CA+AkT2gHKtz2bKSf2FB+3+XkDidBnUDQSZy_KPb1y-MG+QnSiw@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 19, 2015 at 2:04 PM, jacob jacob <opstkusr@gmail.com> wrote:
> I have updated to latest firmware and still no luck.

[...]

> [   61.554132] i40e 0000:00:06.0 eth2: the driver failed to link
> because an unqualified module was detected.     <<<<<<<<<<<<<<<<<<<<
> [   61.555331] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready
>

So I assume you're getting traffic on the other port and it doesn't
complain about "unqualified module"?  Does the problem move if you
swap the cables?  The usual problem here is a QSFP connector that
isn't compatible with the NIC.  I don't have a pointer handy to the
official list, but you should be able to get that from your NIC
supplier.

sln
