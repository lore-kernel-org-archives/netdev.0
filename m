From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH 1/1] NUMA aware scheduling per cpu vhost thread
Date: Fri, 23 Mar 2012 14:21:04 -0700
Message-ID: <4F6CE940.6010209@hp.com>
References: <1332460136.7730.19.camel@oc3660625478.ibm.com> <1510318.F8gXLSD366@tomlt1.ibmoffice.com> <4F6CC866.1090602@hp.com> <2657507.ZkkGW14H3c@tomlt1.ibmoffice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <2657507.ZkkGW14H3c@tomlt1.ibmoffice.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>
> Yeah, it becomes a question of time.  I run each test 3 times and
> average the results, so to run the full suite takes a long time.

I've found the "walk up the instance count with the interim results 
emitted" allows me quicker overall run time than launching all the 
netperfs at once with a long run time to kludge around skew.  Well 
modulo the time it takes to get them all launched.  But for the smallish 
stuff it is rather faster than the 15 minutes a data point I'd get with 
the (ab)use of the confidence intervals mechanism in runemomniagg2.sh . 
  It also avoids the "run one wait for it to finish, run two, wait for 
them to finish, run four, wait for them to finish" bit.  Walking-up the 
instance count leaving the previous instances going does mean that the 
"end of test" information is full of skew, but a great deal of that 
end-of-test information is invariant anyway.

happy benchmarking,

rick jones
