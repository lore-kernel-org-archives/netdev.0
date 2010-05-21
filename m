From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 1/3] cgroups: Add an API to attach a task to current task's
 cgroup
Date: Fri, 21 May 2010 08:09:14 -0700
Message-ID: <4BF6A21A.60405@us.ibm.com>
References: <1274227488.2370.107.camel@w-sridhar.beaverton.ibm.com> <AANLkTinsrFoLVKDFM5pcKcL_6MvAzhR6IzbNmWKh3BDh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Paul Menage <menage@google.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <AANLkTinsrFoLVKDFM5pcKcL_6MvAzhR6IzbNmWKh3BDh@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/20/2010 3:22 PM, Paul Menage wrote:
> On Tue, May 18, 2010 at 5:04 PM, Sridhar Samudrala
> <samudrala.sridhar@gmail.com>  wrote:
>    
>> Add a new kernel API to attach a task to current task's cgroup
>> in all the active hierarchies.
>>
>> Signed-off-by: Sridhar Samudrala<sri@us.ibm.com>
>>      
> Reviewed-by: Paul Menage<menage@google.com>
>
> It would be more efficient to just attach directly to current->cgroups
> rather than potentially creating/destroying one css_set for each
> hierarchy until we've completely converged on current->cgroups - but
> that would require a bunch of refactoring of the guts of
> cgroup_attach_task() to ensure that the right can_attach()/attach()
> callbacks are made. That doesn't really seem worthwhile right now for
> the initial use, that I imagine isn't going to be
> performance-sensitive.
>    
Yes. In our use-case, this will be called only once per guest interface 
when the guest comes up.
Hope you or someone more familiar with cgroups subsystem can optimize 
this function later.

Thanks
Sridhar

