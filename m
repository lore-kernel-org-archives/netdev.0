From: Paul Menage <menage@google.com>
Subject: Re: [PATCH 1/3] cgroups: Add an API to attach a task to current
	task's cgroup
Date: Thu, 20 May 2010 15:26:52 -0700
Message-ID: <AANLkTiknLBB9WkWwnyMQv-qmCFE0HpWIo5L20b79DgLs@mail.gmail.com>
References: <1274227488.2370.107.camel@w-sridhar.beaverton.ibm.com>
	 <AANLkTinsrFoLVKDFM5pcKcL_6MvAzhR6IzbNmWKh3BDh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinsrFoLVKDFM5pcKcL_6MvAzhR6IzbNmWKh3BDh@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 20, 2010 at 3:22 PM, Paul Menage <menage@google.com> wrote:
> On Tue, May 18, 2010 at 5:04 PM, Sridhar Samudrala
> <samudrala.sridhar@gmail.com> wrote:
>> Add a new kernel API to attach a task to current task's cgroup
>> in all the active hierarchies.
>>
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>
> Reviewed-by: Paul Menage <menage@google.com>
>

One other thought on this - this would be the first piece of code
that's attaching a task to a cgroup without holding the cgroup
directory inode i_mutex. I believe that this is probably OK.

Paul
