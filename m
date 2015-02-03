From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 17/18] vhost: don't bother copying iovecs in
 handle_rx(), kill memcpy_toiovecend()
Date: Tue, 3 Feb 2015 16:21:54 +0100
Message-ID: <20150203152154.GA9072@redhat.com>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <1422863977-17668-17-git-send-email-viro@ZenIV.linux.org.uk>
 <20150203100412.GA4896@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150203100412.GA4896@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hmm having second thoughts here.
> Will this modify the iov in vq->iov?
> If yes, how will recvmsg fill it?

OK that was just me misunderstanding what the
function does. As it doesn't modify the iovec itself,
I think there's no issue, my ack stands.
