From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Tue, 24 Mar 2015 07:53:24 -0700
Message-ID: <CAP-MU4P9wXNwgagFNVL4WCK2Xn29hX+DUa=zvBncC8h4c+FMMg@mail.gmail.com>
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
	<CA+AkT2hJcHBcTzyONosrd82dD1m3-ML1_doS=tjBFoAPdnTmaw@mail.gmail.com>
	<550ADAD2.8070506@redhat.com>
	<CA+AkT2jPV_P436_RUQepT7wHtPaGOYGeE5uzUKtyXtk0s8U_gQ@mail.gmail.com>
	<550FBE70.40201@redhat.com>
	<CA+AkT2hoBZ63Pb3MiFV6X=StaU8eAQWb79AbwSLjH7bdoCL6yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefan Assmann <sassmann@redhat.com>, Bandan Das <bsd@redhat.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: jacob jacob <opstkusr@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CA+AkT2hoBZ63Pb3MiFV6X=StaU8eAQWb79AbwSLjH7bdoCL6yA@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 24, 2015 at 7:13 AM, jacob jacob <opstkusr@gmail.com> wrote:
> After update to latest firmware and using version 1.2.37 of i40e
> driver, things are looking better with PCI passthrough.
>
> ]# ethtool -i eth3
> driver: i40e
> version: 1.2.37
> firmware-version: f4.33.31377 a1.2 n4.42 e1930
> bus-info: 0000:00:07.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: yes

I'm glad the updates helped as we expected.

>
> There are still issues running dpdk 1.8.0 from the VM using the pci
> passthrough devices and looks like it puts the devices in a bad state.
> i40e driver will not bind after this happens and a host reboot is
> required to recover.

Did you make sure to unbind the i40e device from pci-stub after you
were done with using it in the VM?

> I'll post further updates as i make progress.
> Thanks for all the help.
>

Good luck,
sln
