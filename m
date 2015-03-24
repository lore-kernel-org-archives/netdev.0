From: jacob jacob <opstkusr@gmail.com>
Subject: Re: PCI passthrough of 40G ethernet interface
	(Openstack/KVM)
Date: Tue, 24 Mar 2015 11:04:48 -0400
Message-ID: <CA+AkT2gt5nxJxE5+h3=5bQ1-upoQCmq88VHneOAUCmPESESjHQ@mail.gmail.com>
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
	<CA+AkT2hJcHBcTzyONosrd82dD1m3-ML1_doS=tjBFoAPdnTmaw@mail.gmail.com>
	<550ADAD2.8070506@redhat.com>
	<CA+AkT2jPV_P436_RUQepT7wHtPaGOYGeE5uzUKtyXtk0s8U_gQ@mail.gmail.com>
	<550FBE70.40201@redhat.com>
	<CA+AkT2hoBZ63Pb3MiFV6X=StaU8eAQWb79AbwSLjH7bdoCL6yA@mail.gmail.com>
	<CAP-MU4P9wXNwgagFNVL4WCK2Xn29hX+DUa=zvBncC8h4c+FMMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>, Bandan Das <bsd@redhat.com>,
	Stefan Assmann <sassmann@redhat.com>
To: Shannon Nelson <shannon.nelson@intel.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <CAP-MU4P9wXNwgagFNVL4WCK2Xn29hX+DUa=zvBncC8h4c+FMMg@mail.gmail.com>
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

On Tue, Mar 24, 2015 at 10:53 AM, Shannon Nelson
<shannon.nelson@intel.com> wrote:
> On Tue, Mar 24, 2015 at 7:13 AM, jacob jacob <opstkusr@gmail.com> wrote:
>> After update to latest firmware and using version 1.2.37 of i40e
>> driver, things are looking better with PCI passthrough.
>>
>> ]# ethtool -i eth3
>> driver: i40e
>> version: 1.2.37
>> firmware-version: f4.33.31377 a1.2 n4.42 e1930
>> bus-info: 0000:00:07.0
>> supports-statistics: yes
>> supports-test: yes
>> supports-eeprom-access: yes
>> supports-register-dump: yes
>> supports-priv-flags: yes
>
> I'm glad the updates helped as we expected.
>
>>
>> There are still issues running dpdk 1.8.0 from the VM using the pci
>> passthrough devices and looks like it puts the devices in a bad state.
>> i40e driver will not bind after this happens and a host reboot is
>> required to recover.
>
> Did you make sure to unbind the i40e device from pci-stub after you
> were done with using it in the VM?

The issue is running dpdk from within the vm itself. Is it possible
that the igb_uio driver needs additional updates/functionality to be
at parity with 1.2.37 version of i40e driver?

>
>> I'll post further updates as i make progress.
>> Thanks for all the help.
>>
>
> Good luck,
> sln
