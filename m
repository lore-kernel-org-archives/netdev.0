From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Tue, 22 Nov 2011 10:14:16 -0800
Message-ID: <20111122101416.7bccf6c6@nehalam.linuxnetplumber.net>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>
	<20111113102428.GD15322@redhat.com>
	<1321196430.2425.2.camel@sasha>
	<4EC07729.3050303@gmail.com>
	<CAOJsxLE4yRO+5XncrDEzVh5-RGXG+=HGTAmQ=bX=KMsDqf=feA@mail.gmail.com>
	<20111114130507.GA18288@redhat.com>
	<877h31ortx.fsf@rustcorp.com.au>
	<20111116072317.GG5433@redhat.com>
	<87bos6b936.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Pekka Enberg <penberg@kernel.org>,
	Asias He <asias.hejun@gmail.com>,
	Sasha Levin <levinsasha928@gmail.com>, kvm@vger.kernel.org,
	mingo@elte.hu, gorcunov@gmail.com,
	Krishna Kumar <krkumar2@in.ibm.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <87bos6b936.fsf@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have been playing with userspace-rcu which has a number of neat
lockless routines for queuing and hashing. But there aren't kernel versions
and several of them may require cmpxchg to work.

