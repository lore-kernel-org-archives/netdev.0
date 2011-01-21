From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Fri, 21 Jan 2011 10:04:43 -0800
Message-ID: <4D39CABB.8030300@hp.com>
References: <20110113064718.GA17905@verge.net.au>	<AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>	<20110113234135.GC8426@verge.net.au>	<20110114045818.GA29738@redhat.com>	<20110114063528.GB10957@verge.net.au>	<20110114065415.GA30300@redhat.com>	<20110116223728.GA6279@verge.net.au>	<20110117102655.GH23479@redhat.com> <4D35ECE2.4040901@hp.com>	<20110120083727.GA1807@verge.net.au> <20110121095929.GE26070@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:44314 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab1AUSEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 13:04:47 -0500
In-Reply-To: <20110121095929.GE26070@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>I have constructed a test where I run an un-paced  UDP_STREAM test in
>>one guest and a paced omni rr test in another guest at the same time.
> 
> 
> Hmm, what is this supposed to measure?  Basically each time you run an
> un-paced UDP_STREAM you get some random load on the network.

Well, if the netperf is (effectively) pinned to a given CPU, presumably it would 
be trying to generate UDP datagrams at the same rate each time.  Indeed though, 
no guarantee that rate would consistently get through each time.

But then, that is where one can use the confidence intervals options to get an 
idea by how much the rate varied.

rick jones
