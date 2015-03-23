From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Mon, 23 Mar 2015 08:19:12 +0100
Message-ID: <550FBE70.40201@redhat.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>	<jpg8uf2ghln.fsf@redhat.com>	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>	<jpgtwxpvk5x.fsf@redhat.com>	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>	<jpg1tko7qwb.fsf@redhat.com>	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>	<jpglhiw4tal.fsf@redhat.com>	<jpgk2yewcpt.fsf@redhat.com>	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>	<CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>	<CAP-MU4Pfv9W9FgaLxwOac3LnSJMxWcbYP4Pq43YjcJ9AWAamvQ@mail.gmail.com>	<550A85B3.4070703@redhat.com>	<CA+AkT2hJcHBcTzyONosrd82dD1m3-ML1_doS=tjBFoAPdnTmaw@mail.gma
 il.com>	<550ADAD2.8070506@redhat.com> <CA+AkT2jPV_P436_RUQepT7wHtPaGOYGeE5uzUKtyXtk0s8U_gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>,
	Bandan Das <bsd@redhat.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: jacob jacob <opstkusr@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CA+AkT2jPV_P436_RUQepT7wHtPaGOYGeE5uzUKtyXtk0s8U_gQ@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20.03.2015 21:55, jacob jacob wrote:
> On Thu, Mar 19, 2015 at 10:18 AM, Stefan Assmann <sassmann@redhat.com> wrote:
>> On 19.03.2015 15:04, jacob jacob wrote:
>>> Hi Stefan,
>>> have you been able to get PCI passthrough working without any issues
>>> after the upgrade?
>>
>> My XL710 fails to transfer regular TCP traffic (netperf). If that works
>> for you then you're already one step ahead of me. Afraid I can't help
>> you there.
> 
> I have data transfer working when trying the test runs on the host
> itself. Are you seeing problems when directly trying the TCP traffic
> from the host itself?

Correct.

> The issues that i am seeing are specific to the case when the devices
> are passed via PCI passthrough into the VM.
> 
> Any ideas whether this would be a kvm/qemu or i40e driver issue?
> (Updating to the latest firmware and using latest i40e driver didn't
> seem to help.)

Hard to say, that's probably something for Intel to look into.

  Stefan
