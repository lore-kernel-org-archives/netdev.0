From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopbackconnections.
Date: Wed, 13 Feb 2008 10:03:16 -0600
Message-ID: <47B314C4.2080905@opengridcomputing.com>
References: <20080212220929.24442.76874.stgit@dell3.ogc.int>	<adafxvxvgz3.fsf@cisco.com>
	<015c01c86e21$75317210$05c8a8c0@DIEGO>	<adaskzwuaeu.fsf@cisco.com>
	<adaodakua9v.fsf@cisco.com>
	<47B3120B.3040409@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <47B3120B.3040409@opengridcomputing.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> Roland Dreier wrote:
>> Steve, I had to update the patch adding an include and fixing the
>> function declaration (as below)... but how much testing have you done
>> with this??
>>
> 
> Now I understand.  I thought I'd fixed these!  I fixed them locally in 
> the test tree on my victim and then tested, but forgot to update my git 
> tree.
> 
> Sorry for this.
> 
> You want me to resubmit?
> 

BTW: Testing:  I cloned my git tree, resolved the two compile issues 
(void + include), then built and installed the kernel (2.6.25-rc1 + the 
fixed patch).  I then ensured that a connection to the local address 
caused the ENOSYS error.

I just forgot to pull the updated file back into my stg managed git tree.

:(
