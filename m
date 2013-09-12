From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCHSET] sysfs: disentangle kobject namespace handling from sysfs
Date: Wed, 11 Sep 2013 20:38:32 -0700
Message-ID: <87eh8u4slj.fsf@xmission.com>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
	<20130912031912.GA9773@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org,
	kay@vrfy.org, netdev@vger.kernel.org, lizefan@huawei.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130912031912.GA9773@kroah.com> (Greg KH's message of "Wed, 11
	Sep 2013 20:19:12 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@linuxfoundation.org> writes:

> On Wed, Sep 11, 2013 at 10:29:02PM -0400, Tejun Heo wrote:
>> Hello,
>> 
>> I'll send out multiple patchsets to separate out sysfs from driver
>> core and kobject.  The eventual goal is making sysfs modular enough so
>> that cgroup can replace its nightmarish cgroupfs implementation which
>> repeated and worsened all the past mistakes of sysfs.  This patchset
>> is first of the effort and separates out kobject namespace handling
>> from sysfs.
>> 
>> I never really understood why namespace support was added the way it
>> was added.
>
> I just took the patches and didn't ask questions :)

Greg you don't get to play dumb you asked questions and required most of
the current strucuture of the code.

The code is convoluted by your request.

Eric
