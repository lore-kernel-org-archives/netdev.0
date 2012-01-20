From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v2 0/5] SUNRPC: make caches network namespace aware
Date: Fri, 20 Jan 2012 15:09:51 +0400
Message-ID: <4F194B7F.4030002@parallels.com>
References: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've tested NFSd under load - works like a charm (showmount reported right info).
I've tested NFS mounts on host node - looks like all works fine.
Also I've tested NFS mounts on host node and in container in the same time. 
There are some problems here. Most likely caused by user-space daemons, 
conflicting between themselves because of wrong initialization environment (like 
rpcbind registering problems, which I've raised in the list already).
So looks like the patches suitable for devel branch.

BTW, thanks to careful review, Bruce.

-- 
Best regards,
Stanislav Kinsbursky
